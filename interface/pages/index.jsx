import { Card, Typography } from '@mui/material';
import { Container } from '@mui/system';
import { useAccount } from 'wagmi';
import DefaultPageLayout from '../src/components/DefaultPageLayout';
import useSSRCheck from '../src/hooks/useSRRCheck';

export default function Home() {
  const { address } = useAccount();
  const { isSSR } = useSSRCheck();

  return (
    <DefaultPageLayout>
      <Container sx={{p: 4}}>
        <Card>
          <Container>
            <p>
              Connected Address: {!isSSR && (address || 'Not Connected')}
            </p>
          </Container>
        </Card>
      </Container>
    </DefaultPageLayout>
  );
};
