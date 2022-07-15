import NavBar from "./NavBar";

export default function DefaultPageLayout({children}) {
  return (
    <div>
      <NavBar />
      {children}
    </div>
  );
}
