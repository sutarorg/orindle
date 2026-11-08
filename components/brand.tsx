import Link from 'next/link';
import { Orbit } from 'lucide-react';
export function Brand({light=false}:{light?:boolean}) { return <Link href="/" className={`brand ${light?'brand-light':''}`} aria-label="Orindle home"><span className="brand-mark"><Orbit size={21} strokeWidth={2.2}/><i/></span><span>orindle</span></Link> }
export function LogoMark(){return <span className="brand-mark" aria-hidden="true"><Orbit size={21} strokeWidth={2.2}/><i/></span>}
