import {describe,expect,it} from 'vitest';
import {validateUploadedBytes} from '../lib/storage/validation';

describe('uploaded file signature validation',()=>{
  it('accepts a PNG with the required file signature',()=>{
    const bytes=Uint8Array.from([137,80,78,71,13,10,26,10,0,0,0,0]);
    expect(()=>validateUploadedBytes('image/png',bytes)).not.toThrow();
  });
  it('rejects a PNG whose claimed MIME type does not match its bytes',()=>{
    expect(()=>validateUploadedBytes('image/png',new TextEncoder().encode('not an image'))).toThrowError('file_signature_mismatch');
  });
  it('rejects empty files and binary bytes disguised as plain text',()=>{
    expect(()=>validateUploadedBytes('text/plain',new Uint8Array())).toThrowError('empty_upload');
    expect(()=>validateUploadedBytes('text/plain',Uint8Array.from([97,0,98]))).toThrowError('invalid_text_upload');
  });
  it('validates JSON syntax rather than trusting the declared content type',()=>{
    expect(()=>validateUploadedBytes('application/json',new TextEncoder().encode('{"ok":true}'))).not.toThrow();
    expect(()=>validateUploadedBytes('application/json',new TextEncoder().encode('{oops'))).toThrowError('invalid_json_upload');
  });
  it('rejects invalid UTF-8 text',()=>{
    expect(()=>validateUploadedBytes('text/csv',Uint8Array.from([0xc3,0x28]))).toThrow();
  });
});
