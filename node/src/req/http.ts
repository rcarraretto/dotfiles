import * as https from 'https';
import * as http from 'http';

export interface HttpRequest {
  url: string;
  method: string;
  data?: any;
  headers?: Record<string, string>;
  ca?: Buffer;
  cert?: Buffer;
  key?: Buffer;
  insecure?: boolean;
}

export interface HttpResponse {
  statusCode: number;
  body: any;
}

const serializeReqData = (reqData: any, contentType: string): string => {
  if (!reqData) {
    return;
  }
  if (contentType === 'application/x-www-form-urlencoded') {
    const p = new URLSearchParams();
    for (const [key, value] of Object.entries(reqData)) {
      p.append(key, value as string);
    }
    return p.toString();
  }
  return JSON.stringify(reqData);
};

const formatResBody = (body: string, contentType: string): string => {
  if (contentType === 'application/x-www-form-urlencoded') {
    const p = new URLSearchParams(body);
    const o = Object.fromEntries(p);
    return JSON.stringify(o);
  }
  return body;
};

export const httpRequest = async (req: HttpRequest): Promise<HttpResponse> => {
  return new Promise((resolve, reject) => {
    const headers = {
      'Content-Type': 'application/json',
      ...req.headers,
    };
    const options: https.RequestOptions = {
      method: req.method,
      headers,
      ca: req.ca,
      cert: req.cert,
      key: req.key,
      rejectUnauthorized: req.insecure !== true,
    };
    const contentType = headers['Content-Type'];
    const reqData = serializeReqData(req.data, contentType);

    const httpLib = req.url.startsWith('https:') ? https : http;
    const httpReq = httpLib.request(req.url, options, (res) => {
      const chunks: any[] = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        let body = Buffer.concat(chunks).toString();
        body = formatResBody(body, contentType);
        resolve({
          statusCode: res.statusCode,
          body,
        });
      });
    });

    httpReq.on('error', (err) => {
      reject(err);
    });

    httpReq.on('timeout', () => {
      httpReq.destroy();
      reject(new Error('Request timed out'));
    });

    if (reqData) {
      httpReq.write(reqData);
    }
    httpReq.end();
  });
};
