import {publicPrice} from '@/lib/billing/pricing';
export const dynamic='force-dynamic';
export async function GET(request:Request){const price=publicPrice(request);const formatted=price.currency==='INR'?`₹${(price.amountMinor/100).toLocaleString('en-IN')}`:`$${(price.amountMinor/100).toFixed(2)}`;return Response.json({plan:'ORINDLE PRO',currency:price.currency,amountMinor:price.amountMinor,formattedPrice:formatted,creditsPerPeriod:1500,available:price.available},{headers:{'Cache-Control':'private, no-store'}})}
