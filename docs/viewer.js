(async()=>{
 const kind=document.body.dataset.document;
 const status=document.getElementById('updated');
 const direct=document.getElementById('pdf-open');
 const frame=document.getElementById('pdf-frame');
 try{
  const response=await fetch('../documents.json?t='+Date.now(),{cache:'no-store'});
  if(!response.ok)throw new Error('manifest');
  const manifest=await response.json();const doc=manifest.documents[kind];
  if(!doc||!/^files\/(resume|career)\.pdf$/.test(doc.file)||!/^[a-f0-9]{64}$/.test(doc.sha256))throw new Error('document');
  const url=new URL('../'+doc.file,location.href);url.searchParams.set('v',doc.sha256.slice(0,16));
  direct.href=url.href;document.getElementById('fallback-link').href=url.href;
  frame.src=url.href+'#view=FitH';frame.title='조경찬 '+doc.title;
  status.textContent=doc.pages+'쪽 · '+doc.updatedAt+' 업데이트';
 }catch(error){
  status.textContent='문서 정보를 불러오지 못했습니다';
  document.getElementById('viewer-message').textContent='아래 링크로 PDF를 직접 열어주세요.';
 }
})();
