import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchMessages } from '../actions';
import { Card } from '../components/bs';
import FriendlyName from '../components/friendly_name';
import Message from '../components/message';
import MessageTitle from '../components/message_title';
import Expandable from '../components/expandable';

class CardMessages extends Component {
  componentDidMount() {
    this.props.fetchMessages(this.props.house_id);
  }

  render() {
    return (
      <Card title="Mes messages"
            action={<a className=""
               href="https://drive.google.com/drive/folders/1CLU7iON-CSUNud5i_b1nI1LBbnF83_gl?usp=sharing"
               target="_blank">Trouver un nouveau 🤙</a>}>
         <Expandable show={3} items={this.props.messages}>
            { (message, hide) =>
              <Message message={message}
                created_at_prefix="Reçu le"
                title={<MessageTitle message={message} />}
                to={<div><strong><FriendlyName firstname={message.user.firstname} lastname={message.user.lastname} /></strong>
                    <i>, <a href={message.user.bio_url} target="_blank">{message.user.bio_title}</a></i></div>}
                 hidden={hide}/>
            }
         </Expandable>
      </Card>
    )
  }
}

function mapStateToProps(state) {
  return { messages: state.houses.messages }
}

export default connect(mapStateToProps, { fetchMessages })(CardMessages);