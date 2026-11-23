# 조경찬 제출 서류

대표 이력서와 경력기술서의 고정 링크 및 Windows 업데이트 코드입니다.

- 대표 이력서: https://whrod.github.io/career-documents/resume/
- 경력기술서: https://whrod.github.io/career-documents/career/
- PDF 직접 열기: `files/resume.pdf`, `files/career.pdf`

## 구조

`docs`는 GitHub Pages 공개 파일, `scripts/publish.ps1`은 저장된 Word를 PDF로 변환하고 Git에 반영하는 코드, `scripts/install-sync.ps1`은 Windows 작업 스케줄러 등록 코드입니다. Pages 게시 원본은 `main`의 `/docs`입니다. 웹 링크에는 날짜나 버전을 붙이지 않습니다. 각 PDF의 내용 해시는 뷰어 URL에 반영해 변경 후 이전 PDF 캐시를 피합니다.

## 업데이트

Windows에 Microsoft Word, PowerShell 7, Git, 인증된 GitHub CLI, Python의 pdf2image·pypdf·Pillow 및 Poppler가 필요합니다. 먼저 저장소를 체크아웃한 뒤 `config.example.json`을 `config.local.json`으로 복사하고 두 문서의 정확한 경로를 지정합니다. 상대 경로는 저장소 루트 기준입니다. Python이 PATH에 없으면 로컬 설정에 python 키로 실행 파일의 절대 경로를 지정합니다. 문서 미리보기는 같은 PDF에서 생성한 페이지 이미지로 표시해 내장 PDF 뷰어가 없는 모바일·앱에서도 읽을 수 있게 했습니다. 직접 열기는 원본 PDF를 제공합니다.

```powershell
pwsh -File scripts/publish.ps1
pwsh -File scripts/install-sync.ps1
```

작업은 로그인된 Windows 세션에서 2분마다 변경 여부를 확인합니다. 저장한 Word만 대상이며 저장하지 않은 편집은 게시하지 않습니다. PC가 꺼지거나 절전 중이면 업데이트는 대기하지만 게시된 링크는 계속 열립니다. PDF 변환과 GitHub Pages 배포 시간이 추가로 필요하므로 실시간 동기화는 아닙니다. 새 버전의 Word를 만들면 `config.local.json`의 해당 source를 변경합니다. Git 충돌이나 Word 변환 실패 시 마지막 게시본을 유지하며 `.local/last-run.json`에 실패를 기록합니다. 원격 변경이 있다면 먼저 pull하고 다시 실행합니다.

## 공개 범위

이 저장소의 페이지, PDF와 Git 이력은 공개입니다. 연락처를 포함한 제출용 문서 두 개만 게시합니다. Word 원본, 로컬 경로 설정, 경력 원본, 지원 현황, 회사 내부 자료와 인증 정보는 게시 대상에 포함하지 않습니다. robots/noindex는 검색 억제를 위한 권고이며 접근 제어가 아닙니다.
