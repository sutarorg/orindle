import 'server-only';
import {S3Client,PutObjectCommand,HeadObjectCommand,GetObjectCommand,DeleteObjectCommand} from '@aws-sdk/client-s3';
import {getSignedUrl} from '@aws-sdk/s3-request-presigner';
import {requireEnv} from '@/lib/http';
let client:S3Client|undefined;
export function r2Client(){if(client)return client;const account=requireEnv('R2_ACCOUNT_ID');client=new S3Client({region:'auto',endpoint:`https://${account}.r2.cloudflarestorage.com`,forcePathStyle:true,credentials:{accessKeyId:requireEnv('R2_ACCESS_KEY_ID'),secretAccessKey:requireEnv('R2_SECRET_ACCESS_KEY')}});return client}
export const r2Bucket=()=>requireEnv('R2_BUCKET');
export async function signedPut(key:string,mime:string,size:number){return getSignedUrl(r2Client(),new PutObjectCommand({Bucket:r2Bucket(),Key:key,ContentType:mime,ContentLength:size}),{expiresIn:300})}
export async function signedGet(key:string,mime?:string,disposition:'attachment'|'inline'='attachment'){return getSignedUrl(r2Client(),new GetObjectCommand({Bucket:r2Bucket(),Key:key,ResponseContentType:mime,ResponseContentDisposition:disposition}),{expiresIn:300})}
export async function putBuffer(key:string,body:Buffer,mime:string){await r2Client().send(new PutObjectCommand({Bucket:r2Bucket(),Key:key,Body:body,ContentType:mime,ContentLength:body.byteLength}))}
export async function getHead(key:string){return r2Client().send(new HeadObjectCommand({Bucket:r2Bucket(),Key:key}))}
export async function readObject(key:string,maxBytes=26*1024*1024){const result=await r2Client().send(new GetObjectCommand({Bucket:r2Bucket(),Key:key}));if(!result.Body)throw new Error('OBJECT_EMPTY');const bytes=await result.Body.transformToByteArray();if(bytes.byteLength>maxBytes)throw new Error('OBJECT_TOO_LARGE');return Buffer.from(bytes)}
export async function deleteObject(key:string){await r2Client().send(new DeleteObjectCommand({Bucket:r2Bucket(),Key:key}))}
