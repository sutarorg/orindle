import 'server-only';
import DodoPayments from 'dodopayments';
import {requireEnv} from '@/lib/http';
import {validateLiveBillingMode} from './pricing';
export function dodoClient(){const environment=validateLiveBillingMode();return new DodoPayments({bearerToken:requireEnv('DODO_API_KEY'),environment,webhookKey:process.env.DODO_WEBHOOK_SECRET,timeout:12_000,maxRetries:1})}
