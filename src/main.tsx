import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';

// Fix for _.info error - define comprehensive global _ object before any modules load
if (typeof (window as any)._ === 'undefined') {
  // Create a comprehensive lodash-like object to prevent PayPal SDK errors
  const mockLodash = {
    // Logging methods
    info: (...args: any[]) => console.info(...args),
    log: (...args: any[]) => console.log(...args), 
    debug: (...args: any[]) => console.debug(...args),
    error: (...args: any[]) => console.error(...args),
    warn: (...args: any[]) => console.warn(...args),
    
    // Common lodash methods that might be used
    isArray: (value: any) => Array.isArray(value),
    isObject: (value: any) => value !== null && typeof value === 'object',
    isString: (value: any) => typeof value === 'string',
    isFunction: (value: any) => typeof value === 'function',
    isUndefined: (value: any) => typeof value === 'undefined',
    isNull: (value: any) => value === null,
    isEmpty: (value: any) => {
      if (value == null) return true;
      if (Array.isArray(value) || typeof value === 'string') return value.length === 0;
      if (typeof value === 'object') return Object.keys(value).length === 0;
      return false;
    },
    
    // Utility methods
    get: (obj: any, path: string, defaultValue?: any) => {
      try {
        return path.split('.').reduce((o, p) => o?.[p], obj) ?? defaultValue;
      } catch {
        return defaultValue;
      }
    },
    set: (obj: any, path: string, value: any) => {
      const keys = path.split('.');
      const lastKey = keys.pop();
      const target = keys.reduce((o, k) => o[k] = o[k] || {}, obj);
      if (lastKey) target[lastKey] = value;
      return obj;
    },
    merge: (target: any, ...sources: any[]) => Object.assign(target, ...sources),
    clone: (value: any) => {
      try {
        return JSON.parse(JSON.stringify(value));
      } catch {
        return value;
      }
    },
    
    // Array methods
    map: (array: any[], fn: Function) => Array.isArray(array) ? array.map(fn) : [],
    filter: (array: any[], fn: Function) => Array.isArray(array) ? array.filter(fn) : [],
    find: (array: any[], fn: Function) => Array.isArray(array) ? array.find(fn) : undefined,
    
    // Default fallback for any other method
    [Symbol.for('nodejs.util.inspect.custom')]: () => '[Mock Lodash Object]'
  };

  // Create proxy to handle any missing methods
  (window as any)._ = new Proxy(mockLodash, {
    get(target, prop) {
      if (prop in target) {
        return target[prop as keyof typeof target];
      }
      // For any unknown method, return a no-op function or appropriate default
      if (typeof prop === 'string') {
        console.warn(`Mock lodash: Missing method _.${prop}, returning no-op`);
        return (...args: any[]) => {
          console.debug(`Mock lodash: _.${prop} called with:`, args);
          return undefined;
        };
      }
      return undefined;
    }
  });
  
  console.info('✅ Mock lodash initialized to prevent _.info errors');
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
