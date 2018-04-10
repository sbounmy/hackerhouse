import React, { Component } from 'react';
import TypeForm from './typeform';

export default props => {
  return (
    <Card className='mb-4 d-lg-block'
          title="Mes meetups 🗣">
      <p>Chaque semaine un meetup : https://www.meetup.com/HackerHouse-Paris</p>
      <p>MardX : de 19:00 à 20:30</p>
      <p className='text-right'>
        <TypeForm id="f6Lzio" text="Organiser mon meetup 🎤"/>
      </p>
    </Card>
  )
}