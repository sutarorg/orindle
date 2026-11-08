import type { Metadata } from 'next';
import localFont from 'next/font/local';
import './globals.css';
const poppins = localFont({src:[{path:'../public/fonts/poppins-latin-400-normal.woff2',weight:'400'},{path:'../public/fonts/poppins-latin-500-normal.woff2',weight:'500'},{path:'../public/fonts/poppins-latin-600-normal.woff2',weight:'600'},{path:'../public/fonts/poppins-latin-700-normal.woff2',weight:'700'}], variable:'--font-poppins', display:'swap'});
export const metadata: Metadata = {title:'Orindle — One workspace for AI', description:'Chat, create images and videos, and build standalone HTML websites in one considered workspace.'};
export default function RootLayout({children}:{children:React.ReactNode}) {return <html lang="en"><body className={poppins.variable}>{children}</body></html>}
