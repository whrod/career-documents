(async () => {
 const label = document.getElementById('document-updated');
 try {
  const response = await fetch('./documents.json?t=' + Date.now(), {cache:'no-store'});
  if (!response.ok) throw new Error('manifest unavailable');
  const manifest = await response.json();
  const dates = Object.values(manifest.documents || {}).map(doc => doc.updatedAt).filter(value => typeof value === 'string' && /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(value)).sort();
  if (!dates.length) throw new Error('date unavailable');
  const date = dates[dates.length - 1].slice(0,10);
  const time = document.createElement('time');
  time.dateTime = date;
  time.textContent = date.replaceAll('-', '.');
  label.replaceChildren('최종 업데이트 ', time);
 } catch {
  label.textContent = '문서별 업데이트 날짜는 각 서류에서 확인할 수 있습니다.';
 }
})();
