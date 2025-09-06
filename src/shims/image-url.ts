import { resolveImageUrl, getSignedImageUrl } from '@/services/api';
;(globalThis as any).resolveImageUrl = resolveImageUrl;
;(globalThis as any).getSignedImageUrl = getSignedImageUrl;