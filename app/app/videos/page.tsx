import {VideoWorkspace} from '@/components/app-shell';
export const dynamic='force-dynamic';
export default async function Videos({searchParams}:{searchParams:Promise<{jobId?:string}>}){const params=await searchParams;return <VideoWorkspace initialJobId={params.jobId}/>}
