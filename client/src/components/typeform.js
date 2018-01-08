import React from 'react';
{/*<a class="typeform-share button" href="https://hackerhouseparis.typeform.com/to/f6Lzio" data-mode="popup" style="display:inline-block;text-decoration:none;background-color:#267DDD;color:white;cursor:pointer;font-family:Helvetica,Arial,sans-serif;font-size:20px;line-height:50px;text-align:center;margin:0;height:50px;padding:0px 33px;border-radius:25px;max-width:100%;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-weight:bold;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;" target="_blank">Launch me </a> <script> (function() { var qs,js,q,s,d=document, gi=d.getElementById, ce=d.createElement, gt=d.getElementsByTagName, id="typef_orm_share", b="https://embed.typeform.com/"; if(!gi.call(d,id)){ js=ce.call(d,"script"); js.id=id; js.src=b+"embed.js"; q=gt.call(d,"script")[0]; q.parentNode.insertBefore(js,q) } })() </script>*/}

export default function(props) {
  const url = `https://hackerhouseparis.typeform.com/to/${props.id}`
  return (
    <div>
      <a  className="typeform-share button btn btn-primary"
          href={url} data-mode="popup"
          target="_blank">{props.text}
      </a>
    </div>
 );
}

