import React, { Component } from 'react'
import { Button, Card } from './bs'

export default (props) => {
  return <Card title="Mes Documents"
               footer={
                <Button type='outline-primary'
                  message={'Hello la HackerHouse 🤘\n J\'ai besoin du document suivant : '}>
                    J'ai besoin de...
                </Button>
               }>
          <div className="embed-responsive embed-responsive-21by9">
            <iframe className='embed-responsive-item'
                   src={`https://drive.google.com/embeddedfolderview?id=${props.id}#${props.type}`}
                   >
            </iframe>
          </div>
        </Card>
}