import * as https from 'https';
import * as http from 'http';

export interface HttpRequest {
  url: string;
  method: string;
  data?: any;
  headers?: Record<string, string>;
}

export interface HttpResponse {
  statusCode: number;
  body: any;
}

export const httpRequest = async (req: HttpRequest): Promise<HttpResponse> => {
  return new Promise((resolve, reject) => {
    const options: https.RequestOptions = {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        ...req.headers,
      },
    };
    const httpLib = req.url.startsWith('https:') ? https : http;
    const httpReq = httpLib.request(req.url, options, (res) => {
      const body: any[] = [];
      res.on('data', (chunk) => body.push(chunk));
      res.on('end', () => {
        const resString = Buffer.concat(body).toString();
        resolve({
          statusCode: res.statusCode,
          body: resString,
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

    if (req.data) {
      httpReq.write(JSON.stringify(req.data));
    }
    httpReq.end();
  });
};
