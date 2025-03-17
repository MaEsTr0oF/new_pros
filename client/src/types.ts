export interface Profile {
  id: number
  name: string
  age: number
  height: number
  weight: number
  breastSize: number
  phone: string
  description: string
  photos: string[]
  price1Hour: number
  price2Hours: number
  priceNight: number
  priceExpress: number
  workingHours?: string
  isVerified: boolean
  hasVideo: boolean
  hasReviews: boolean
  services: Service[]
  cityId: number
  district?: string
  isActive: boolean
  city?: City
  createdAt?: string
  updatedAt?: string
  verification?: string[]
  price?: number
  outcall?: boolean

  // Appearance
  nationality?: string
  hairColor?: string
  bikiniZone?: string

  // Location
  inCall?: boolean // у себя
  outCall?: boolean // выезд

  // Additional filters
  isNonSmoking?: boolean
  isNew?: boolean
  isWaitingCall?: boolean
  is24Hours?: boolean

  // Neighbors
  isAlone?: boolean
  withFriend?: boolean
  withFriends?: boolean

  // Gender and orientation
  gender: string
  orientation?: string
}

export interface City {
  id: number
  name: string
  code: string
}

export interface Language {
  id: number
  code: string
  name: string
}

export interface AppearanceFilters {
  age: [number, number]
  height: [number, number]
  weight: [number, number]
  breastSize: [number, number]
  nationality: string[]
  hairColor: string[]
  bikiniZone: string[]
}

export interface PriceFilters {
  from: number | null
  to: number | null
  hasExpress: boolean
}

export interface FilterParams {
  gender: string[]
  appearance: AppearanceFilters
  district: string[]
  price: PriceFilters
  services: Service[]
  verification: string[]
  other: string[]
  outcall: boolean
}

export const SERVICE_OPTIONS = [
  'classic',
  'anal',
  'lesbian',
  'group_mmf',
  'group_ffm',
  'with_toys',
  'in_car',
  'blowjob_with_condom',
  'blowjob_without_condom',
  'deep_blowjob',
  'car_blowjob',
  'anilingus_to_client',
  'fisting_to_client',
  'kisses',
  'light_domination',
  'mistress',
  'flogging',
  'trampling',
  'face_sitting',
  'strapon',
  'bondage',
  'slave',
  'role_play',
  'foot_fetish',
  'golden_rain_out',
  'golden_rain_in',
  'copro_out',
  'copro_in',
  'enema',
  'relaxing',
  'professional',
  'body_massage',
  'lingam_massage',
  'four_hands',
  'urological',
  'strip_pro',
  'strip_amateur',
  'belly_dance',
  'twerk',
  'lesbian_show',
  'sex_chat',
  'phone_sex',
  'video_sex',
  'photo_video',
  'invite_girlfriend',
  'invite_friend',
  'escort',
  'photoshoot',
  'skirt'
] as const

export type Service = (typeof SERVICE_OPTIONS)[number]
