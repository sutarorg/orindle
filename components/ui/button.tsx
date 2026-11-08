import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { cva, type VariantProps } from 'class-variance-authority';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) { return twMerge(clsx(inputs)); }
const buttonVariants = cva('ui-button', {
  variants: {
    variant: { default: 'ui-button-default', outline: 'ui-button-outline', ghost: 'ui-button-ghost', link: 'ui-button-link' },
    size: { default: 'ui-button-md', sm: 'ui-button-sm', icon: 'ui-button-icon' },
  },
  defaultVariants: { variant: 'default', size: 'default' },
});
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement>, VariantProps<typeof buttonVariants> { asChild?: boolean }
export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(({className,variant,size,asChild=false,...props},ref)=>{
  const Component = asChild ? Slot : 'button';
  return <Component ref={ref} className={cn(buttonVariants({variant,size}),className)} {...props}/>;
});
Button.displayName='Button';
