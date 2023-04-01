import * as https from 'https';

export interface ReqDetails {
  url: string;
  method: string;
  data?: any;
  headers?: Record<string, string>;
}

export interface HttpResponse {
  statusCode: number;
  body: any;
}

export const httpRequest = async (details: ReqDetails): Promise<HttpResponse> => {
  return new Promise((resolve, reject) => {
    const options: https.RequestOptions = {
      method: details.method,
      headers: {
        'Content-Type': 'application/json',
        ...details.headers,
      },
    };
    const req = https.request(details.url, options, (res) => {
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

    req.on('error', (err) => {
      reject(err);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timed out'));
    });

    if (details.data) {
      req.write(JSON.stringify(details.data));
    }
    req.end();
  });
};
