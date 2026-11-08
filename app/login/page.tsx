import {AuthPage} from '@/components/auth';
export default async function Page({searchParams}:{searchParams:Promise<{error?:string;sent?:string}>}){const query=await searchParams;return <AuthPage path="/login" error={query.error} sent={query.sent}/>}
