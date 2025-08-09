export interface IApiResponseData<T = unknown> {
  success: boolean;
  status?: string;
  message: string;
  data?: T;
  error?: {
    code: string;
    details?: string;
    field?: string;
  };
  meta: {
    timestamp: string;
    requestId?: string; // Front fait une requête -> requestId => à savoir qui a fait la req
    pagination?: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
  };
}
