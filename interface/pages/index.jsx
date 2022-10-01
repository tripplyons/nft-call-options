import { Card, Stack } from '@mui/material';
import { Container } from '@mui/system';
import { useAccount } from 'wagmi';
import DefaultPageLayout from '../src/components/DefaultPageLayout';
import useSSRCheck from '../src/hooks/useSRRCheck';
import BaseCurrency from '../src/components/BaseCurrency';
import SellInterface from '../src/components/SellInterface';

export default function Home() {
  const { address } = useAccount();
  const { isSSR } = useSSRCheck();

  return (
    <DefaultPageLayout>
      <Container sx={{ p: 4 }}>
        <Stack spacing={4}>
          <Card>
            <Container>
              <p>
                Connected Address: {!isSSR && (address || 'Not Connected')}
              </p>
              <p>
                Base Currency: <BaseCurrency />
              </p>
            </Container>
          </Card>
          <SellInterface></SellInterface>
        </Stack>
      </Container>
    </DefaultPageLayout>
  );
};
