import { AppBar, Box, Toolbar, Typography, Button, Container } from "@mui/material";
import { APP_NAME } from "../constants";
import CustomConnectButton from "./CustomConnectButton";

export default function NavBar() {
  return (
    <Box sx={{flexGrow: 1}}>
      <AppBar color="primary" position="static">
        <Container>
          <Toolbar>
              <Typography variant="h6" sx={{flexGrow: 1}}>
                {APP_NAME}
              </Typography>
              <CustomConnectButton Button={(props) => {
                const {children, ...rest} = props;
                return <Button variant="outlined" {...rest}>{children}</Button>
              }} />
          </Toolbar>
        </Container>
      </AppBar>
    </Box>
  )
}