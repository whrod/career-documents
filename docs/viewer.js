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
  const textResponse=await fetch('../previews/'+kind+'/text.json?v='+doc.sha256.slice(0,16));
  const texts=textResponse.ok?await textResponse.json():[];
  frame.replaceChildren();
  for(let i=1;i<=doc.pages;i++){
   const figure=document.createElement('figure');figure.className='pdf-page';
   const image=document.createElement('img');
   image.src='../previews/'+kind+'/page-'+i+'.webp?v='+doc.sha256.slice(0,16);
   image.alt=doc.title+' '+i+'쪽';image.loading=i===1?'eager':'lazy';
   const caption=document.createElement('figcaption');caption.textContent=i+' / '+doc.pages;
   figure.append(image,caption);
   if(texts[i-1]){const text=document.createElement('p');text.className='sr-only';text.textContent=texts[i-1];figure.append(text)}
   frame.append(figure);
  }
  status.textContent=doc.pages+'쪽 · '+doc.updatedAt+' 업데이트';
 }catch(error){
  status.textContent='문서 정보를 불러오지 못했습니다';
  document.getElementById('viewer-message').textContent='아래 링크로 PDF를 직접 열어주세요.';
 }
})();
