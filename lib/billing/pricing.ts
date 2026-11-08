import 'server-only';
import {HttpError} from '@/lib/http';
export type BillingCurrency='USD'|'INR';
const PRICE_MINOR:Record<BillingCurrency,number>={USD:1499,INR:139900};
export function trustedBillingCurrency(request:Request):BillingCurrency{return process.env.VERCEL==='1'&&request.headers.get('x-vercel-ip-country')?.toUpperCase()==='IN'?'INR':'USD'}
export function configuredPrice(currency:BillingCurrency){const productId=process.env[currency==='INR'?'DODO_PRODUCT_INR_ID':'DODO_PRODUCT_USD_ID'];const amount=Number(process.env[currency==='INR'?'DODO_PRICE_INR_MINOR':'DODO_PRICE_USD_MINOR']);if(!productId||amount!==PRICE_MINOR[currency])throw new HttpError(503,'billing_not_configured');return {currency,amountMinor:PRICE_MINOR[currency],productId}}
export function publicPrice(request:Request){const currency=trustedBillingCurrency(request);try{const price=configuredPrice(currency);return {...price,available:true}}catch{return {currency,amountMinor:PRICE_MINOR[currency],available:false}}}
export function validateLiveBillingMode(){const environment=process.env.DODO_ENVIRONMENT||'test_mode';if(!['test_mode','live_mode'].includes(environment))throw new HttpError(503,'billing_environment_invalid');if(environment==='live_mode'&&process.env.DODO_ENABLE_LIVE_BILLING!=='true')throw new HttpError(503,'live_billing_requires_explicit_approval');return environment as 'test_mode'|'live_mode'}
export function expectedPrice(currency:string){if(currency!=='USD'&&currency!=='INR')return null;try{return configuredPrice(currency).amountMinor}catch{return null}}
