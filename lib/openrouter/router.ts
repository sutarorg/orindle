import 'server-only';
import { createAdminClient } from '@/lib/supabase/server';
import { HttpError } from '@/lib/http';
type ModelRow={id:string;model_id:string;canonical_model_id:string|null;display_name:string;description:string|null;context_length:number|null;input_modalities:string[];output_modalities:string[];supported_parameters:string[];model_pricing:{prompt_usd_per_token:string|number|null;completion_usd_per_token:string|number|null}|null};
export type AttachmentCapability='image'|'text';
export function classifyPrompt(prompt:string){const text=prompt.toLowerCase();return {coding:/\b(code|coding|typescript|javascript|python|sql|debug|function|api|react|next\.js|regex)\b/.test(text),reasoning:/\b(analy[sz]e|reason|proof|compare|evaluate|architecture|trade.?off|step by step|derive)\b/.test(text),longContext:prompt.length>10_000}}
function cost(row:ModelRow,inputTokens:number,outputTokens:number){const p=row.model_pricing;if(!p||p.prompt_usd_per_token===null||p.completion_usd_per_token===null)return null;const input=Number(p.prompt_usd_per_token),output=Number(p.completion_usd_per_token);if(!Number.isFinite(input)||!Number.isFinite(output)||input<0||output<0)return null;return input*inputTokens+output*outputTokens}
export async function chooseChatModel({modelId,prompt,inputTokens,outputTokens,attachments=[]}:{modelId?:string|null;prompt:string;inputTokens:number;outputTokens:number;attachments?:AttachmentCapability[]}){
 const admin=createAdminClient();let query=admin.from('model_catalog').select('id,model_id,canonical_model_id,display_name,description,context_length,input_modalities,output_modalities,supported_parameters,model_pricing(prompt_usd_per_token,completion_usd_per_token)').eq('provider','openrouter').eq('active',true).contains('output_modalities',['text']);
 if(modelId&&modelId!=='auto')query=query.eq('id',modelId);
 const {data,error}=await query.limit(modelId&&modelId!=='auto'?1:500);if(error)throw new HttpError(503,'catalogue_unavailable');let models=(data||[]) as unknown as ModelRow[];
 if(modelId&&modelId!=='auto'&&!models.length)throw new HttpError(400,'model_unavailable');
 const required=[...new Set<AttachmentCapability>(['text',...attachments])];
 models=models.filter(m=>(m.context_length||0)>=inputTokens+outputTokens&&required.every(x=>(m.input_modalities||[]).includes(x)));
 if(!models.length)throw new HttpError(422,'no_compatible_model');
 const intent=classifyPrompt(prompt);if(intent.longContext)models=models.filter(m=>(m.context_length||0)>=16_000);if(!models.length)throw new HttpError(422,'no_compatible_context_model');
 const priced=models.map(m=>({model:m,estimatedCostUsd:cost(m,inputTokens,outputTokens)})).filter((x):x is {model:ModelRow;estimatedCostUsd:number}=>x.estimatedCostUsd!==null);
 if(!priced.length)throw new HttpError(503,'model_pricing_unavailable');
 if(modelId&&modelId!=='auto')return priced[0];
 const taskWords=intent.coding?['code','coding','program','developer']:intent.reasoning?['reason','reasoning','analysis','analyze']:[];
 const ranked=priced.map(item=>{const name=`${item.model.display_name} ${item.model.description||''}`.toLowerCase();const taskFit=taskWords.length&&taskWords.some(word=>name.includes(word));const context=Math.min(item.model.context_length||0,200_000);return {...item,score:item.estimatedCostUsd*(intent.coding||intent.reasoning?0.72:1)+(taskFit?-0.0000001:0)-context*1e-14}}).sort((a,b)=>a.score-b.score);
 return ranked[0];
}
export async function creditsForUsd(costUsd:number){if(!Number.isFinite(costUsd)||costUsd<0)throw new HttpError(400,'invalid_cost');const admin=createAdminClient();const {data,error}=await admin.from('system_settings').select('value').eq('key','credits_per_usd').single();if(error)throw new HttpError(503,'credit_config_unavailable');const units=Number(data.value);if(!Number.isSafeInteger(units)||units<1)throw new HttpError(503,'credit_config_unavailable');return Math.ceil(costUsd*units)}
