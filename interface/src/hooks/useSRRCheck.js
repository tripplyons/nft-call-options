import { useState, useEffect } from 'react';

// useful because the server side rendering won't have a wallet
export default function useSSRCheck() {
  const [isSSR, setIsSSR] = useState(true);

  useEffect(() => {
    setIsSSR(false);
  }, []);

  return { isSSR };
}
