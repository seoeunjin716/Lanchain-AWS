import type { Metadata } from 'next';
import './globals.css';
import RegisterSW from './register-sw';

export const metadata: Metadata = {
  title: 'LangChain Chatbot',
  description: 'LangChain과 연동된 AI 챗봇',
  manifest: '/manifest.json',
  themeColor: '#000000',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'LangChain Chatbot',
  },
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <head>
        <link rel="manifest" href="/manifest.json" />
        <link rel="apple-touch-icon" href="/icon-192x192.png" />
        <meta name="theme-color" content="#000000" />
      </head>
      <body>
        {children}
        <RegisterSW />
      </body>
    </html>
  );
}

