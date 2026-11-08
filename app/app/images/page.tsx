import {ImageWorkspace} from '@/components/app-shell';
export const dynamic='force-dynamic';
export default async function Images({searchParams}:{searchParams:Promise<{jobId?:string}>}){const params=await searchParams;return <ImageWorkspace initialJobId={params.jobId}/>}
