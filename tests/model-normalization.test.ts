import {describe,expect,it} from 'vitest';
import {normalizeModel} from '../lib/openrouter/normalize';

describe('OpenRouter model normalization',()=>{
  it('preserves capabilities and canonical identity while applying safe defaults',()=>{
    const model=normalizeModel({id:'vendor/model-v2',canonical_slug:'vendor/model',name:'Model v2',architecture:{input_modalities:['text','image'],output_modalities:['text']},pricing:{prompt:'0.000001',completion:'0.000002'}});
    expect(model).toMatchObject({provider:'vendor',model_id:'vendor/model-v2',canonical_model_id:'vendor/model',display_name:'Model v2',input_modalities:['text','image'],output_modalities:['text'],pricing:{prompt_usd_per_token:'0.000001',completion_usd_per_token:'0.000002'}});
    expect(model.context_length).toBeNull();
  });
  it('does not invent a separate canonical identity when upstream has none',()=>{
    expect(normalizeModel({id:'vendor/model'}).canonical_model_id).toBe('vendor/model');
  });
  it('preserves explicitly supplied zero prices and keeps unknown pricing distinct',()=>{
    expect(normalizeModel({id:'vendor/model',pricing:{prompt:'0'}}).pricing.prompt_usd_per_token).toBe('0');
    expect(normalizeModel({id:'vendor/model'}).pricing.prompt_usd_per_token).toBeNull();
  });
});
