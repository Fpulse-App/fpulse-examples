import Script from 'next/script'

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Script src="https://fpulse.app/w/YOUR_WIDGET_ID.js" strategy="afterInteractive" />
      </body>
    </html>
  )
}
