import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 100 },
    { duration: '1m30s', target: 256 },
    { duration: '20s', target: 0 },
  ],
};

export default function () {
  let res = http.get('http://172.16.29.52:32333/');
  check(res, { 'status was 200': (r) => r.status == 200 });
  //sleep(1);
}
