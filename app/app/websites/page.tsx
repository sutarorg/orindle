import {WebsiteWorkspace} from '@/components/app-shell';
export const dynamic='force-dynamic';
export default async function Websites({searchParams}:{searchParams:Promise<{websiteId?:string}>}){const params=await searchParams;return <WebsiteWorkspace initialWebsiteId={params.websiteId}/>}
