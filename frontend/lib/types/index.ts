export interface User {
  id: number
  email: string
  first_name: string
  last_name: string
  full_name: string
  role: 'donor' | 'admin'
  total_donated: number
  avatar_url?: string
  created_at: string
}

export interface Campaign {
  id: number
  title: string
  description: string
  goal_amount: number
  deadline: string
  status: 'draft' | 'active' | 'completed' | 'cancelled'
  total_raised: number
  percentage_raised: number
  days_remaining: number
  donation_count: number
  is_funded: boolean
  is_expired: boolean
  can_receive_donations: boolean
  image_url?: string
  creator: User
  created_at: string
  updated_at: string
}

export interface Donation {
  id: number
  amount: number
  anonymous: boolean
  status: 'pending' | 'successful' | 'failed' | 'refunded'
  donor_name: string
  display_amount: string
  user: User
  campaign: Campaign
  transaction?: Transaction
  created_at: string
  updated_at: string
}

export interface Transaction {
  id: number
  stripe_payment_intent_id: string
  amount: number
  status: string
  successful: boolean
  failed: boolean
  stripe_url?: string
  created_at: string
  updated_at: string
}

export interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string
  errors?: string[]
}

export interface PaginatedResponse<T> {
  items: T[]
  meta: {
    current_page: number
    next_page?: number
    prev_page?: number
    total_pages: number
    total_count: number
  }
}

export interface LoginCredentials {
  email: string
  password: string
}

export interface RegisterData {
  email: string
  password: string
  password_confirmation: string
  first_name: string
  last_name: string
  role?: 'donor' | 'admin'
}

export interface CreateCampaignData {
  title: string
  description: string
  goal_amount: number
  deadline: string
  image?: File
}

export interface CreateDonationData {
  amount: number
  anonymous: boolean
}
