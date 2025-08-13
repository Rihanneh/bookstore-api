import crypto from 'node:crypto';
import type { Request } from 'express';
/**
 * Générateur de Request ID pour traçabilité
 * KISS: Simple et efficace
 * YAGNI: Pas de validation complexe inutile
 */
export class RequestIdGenerator {
  /**
   * Génère un requestId unique
   */
  public static generate(): string {
    const randomUUID = crypto.randomUUID();
    const requestId = `req_${Date.now()}_${randomUUID}`;
    return requestId;
  }

  /**
   * Récupère le requestId depuis les headers ou génère un nouveau
   */
  public static getFromRequest(req: Request): string {
    // Gestion sécurisée avec optional chaining
    const requestId: string | string[] | undefined = req.headers?.['x-request-id'];

    // Validation stricte du type
    if (typeof requestId === 'string' && requestId.trim()) {
      return requestId.trim();
    }

    return RequestIdGenerator.generate();
  }
}
