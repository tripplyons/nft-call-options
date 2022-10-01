import { useNetwork } from 'wagmi';
import useSSRCheck from '../hooks/useSRRCheck';

export default function BaseCurrency() {
  const { chain } = useNetwork();
  const { isSSR } = useSSRCheck();

  const symbol = chain?.nativeCurrency?.symbol;

  return (
    <>
      {isSSR ? "" : (symbol ? symbol : "")}
    </>
  );
}
