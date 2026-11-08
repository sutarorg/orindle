import { assertAdmin,getAuthenticatedUser } from '@/lib/auth/server';
import { jsonError } from '@/lib/http';
import { synchronizeCatalogue } from '@/lib/openrouter/catalogue';
export const runtime='nodejs';export const dynamic='force-dynamic';export const maxDuration=300;
export async function POST(){try{const user=await getAuthenticatedUser();await assertAdmin(user.id);const result=await synchronizeCatalogue(user.id);return Response.json(result,{status:200,headers:{'Cache-Control':'no-store'}})}catch(error){return jsonError(error)}}
