import React from 'react';

export default props => {
  const { house } = props
  if (!house) return ''

  return (
    <div>
      <strong>{house.name}</strong><i>, <a href='#' target="_blank">{house.zip_code}, {house.city}</a></i>
    </div>
  )
}
