export type Role = 'student' | 'marketing';
export type RequestStatus = 'Pending' | 'Under Review' | 'Approved' | 'Rejected' | 'Preparing' | 'Ready for Pickup' | 'Completed' | 'Cancelled';
export interface UserProfile { id: string; role: Role; name: string; identifier: string; email?: string; phone?: string; program?: string; year?: string; }
export interface Product { id: string; name: string; category: string; description: string; price: number; image: string; sizes: { id: string; label: string; stock: number }[]; }
export interface RequestItem { productId: string; productName: string; sizeId: string; size: string; quantity: number; unitPrice: number; }
export interface UniformRequest { id: string; reference: string; studentId: string; studentName: string; pickup: string; status: RequestStatus; createdAt: string; total: number; items: RequestItem[]; reason?: string; history: { status: RequestStatus; at: string; note?: string }[]; }
export interface Notice { id: string; title: string; message: string; read: boolean; at: string; }
export interface StudentDirectoryEntry { id: string; studentId: string; phinmaEmail: string; fullName: string; program?: string; year?: string; }
export interface RegistrationInvitation { id:string; role:Role; expiresAt:string; revokedAt?:string; usageCount:number; createdAt:string; }
