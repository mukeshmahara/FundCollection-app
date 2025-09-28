import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  // @ts-ignore - twMerge types sometimes mismatch variance
  return twMerge(clsx(inputs))
}
