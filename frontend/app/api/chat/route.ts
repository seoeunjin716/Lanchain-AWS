import { NextRequest, NextResponse } from 'next/server';

// 백엔드 URL (환경 변수에서 가져오거나 기본값 사용)
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:8000';

export async function POST(request: NextRequest) {
  try {
    const { message, history } = await request.json();

    if (!message) {
      return NextResponse.json(
        { error: '메시지가 필요합니다.' },
        { status: 400 }
      );
    }

    // 백엔드 API로 요청 전달
    const response = await fetch(`${BACKEND_URL}/api/v1/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message,
        history,
      }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({
        detail: `백엔드 오류: ${response.status} ${response.statusText}`,
      }));
      throw new Error(errorData.detail || '백엔드 요청 실패');
    }

    const data = await response.json();
    return NextResponse.json(data);
  } catch (error: any) {
    console.error('Chat API Error:', error);
    return NextResponse.json(
      {
        error: '챗봇 응답 생성 중 오류가 발생했습니다.',
        details: error.message,
      },
      { status: 500 }
    );
  }
}

