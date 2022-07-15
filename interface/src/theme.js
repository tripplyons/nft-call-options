import { createTheme } from '@mui/material/styles';
import { ACCENT_COLOR, BG_COLOR, PAPER_COLOR, ERROR_COLOR } from './constants';

// Create a theme instance.
const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: ACCENT_COLOR,
    },
    error: {
      main: ERROR_COLOR,
    },
    background: {
      default: BG_COLOR,
      paper: PAPER_COLOR,
    },
  },
});

export default theme;
