import {AccountWorkspace} from '@/components/app-shell';
export const dynamic='force-dynamic';
const sections:Record<string,string>={profile:'Profile',subscription:'Subscription','credit-usage':'Credit usage','billing-history':'Billing history',security:'Security'};
export default async function Account({searchParams}:{searchParams:Promise<{section?:string;checkout?:string;notice?:string}>}){const params=await searchParams;return <AccountWorkspace initialSection={sections[params.section||'']||'Profile'} checkoutState={params.checkout||params.notice||''}/>}
