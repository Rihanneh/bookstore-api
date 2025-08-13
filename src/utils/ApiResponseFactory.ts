import type { IApiResponseData } from '@/interfaces/http/IApiResponseData';

export class ApiResponseFactory {
  private static generateMeta(requestId?: string): { timestamp: string; requestId?: string } {
    const meta = {
      timestamp: new Date().toISOString(),
      ...(requestId && { requestId })
    };
    return meta;
  }

  public static success<T>(message: string, data?: T, requestId?: string): IApiResponseData<T> {
    const response: IApiResponseData<T> = {
      success: true,
      message,
      ...(data !== undefined && { data }), // Spread conditionnel PRO
      meta: ApiResponseFactory.generateMeta(requestId)
    };
    return response;
  }

  public static error(
    message: string,
    code: string,
    details?: string,
    field?: string,
    requestId?: string
  ): IApiResponseData<null> {
    const errorObject = {
      code,
      ...(details && { details }),
      ...(field && { field })
    };

    const response: IApiResponseData<null> = {
      success: false,
      message,
      error: errorObject,
      meta: ApiResponseFactory.generateMeta(requestId)
    };
    return response;
  }

  public static paginated<T>(
    message: string,
    data: T[],
    page: number,
    limit: number,
    total: number,
    requestId?: string
  ): IApiResponseData<T[]> {
    const paginationInfo = {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    };

    const response: IApiResponseData<T[]> = {
      success: true,
      message,
      data, // data obligatoire ici (T[] jamais undefined)
      meta: {
        ...ApiResponseFactory.generateMeta(requestId),
        pagination: paginationInfo
      }
    };
    return response;
  }
}
