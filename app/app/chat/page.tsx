import {ChatWorkspace} from '@/components/app-shell';
export const dynamic='force-dynamic';
export default async function Chat({searchParams}:{searchParams:Promise<{conversationId?:string}>}){const params=await searchParams;return <ChatWorkspace initialConversationId={params.conversationId}/>}
