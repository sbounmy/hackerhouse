import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchUserMessages, fetchHouses } from '../actions';
import Message from '../components/message';
import MessageTitle from '../components/message_title';
import HouseTitle from '../components/house_title';
import { Card } from '../components/bs';
import Expandable from '../components/expandable';
import _ from 'lodash';
import Moment from 'react-moment';

class CardUserMessages extends Component {

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchUserMessages(this.props.user.id);
      this.props.fetchHouses()
    }
  }

  render() {
    return (
      <Card title="Mes messages">
         <Expandable show={1} items={this.props.messages}>
            { (message, hide) =>
                <Message message={message}
                 created_at_prefix="Envoyé le"
                 title={<MessageTitle message={message}/>}
                 to={<HouseTitle house={this.props.houses[message.house_id]}/>}
                 hidden={hide} />

            }
         </Expandable>
      </Card>
    )
  }
}

function mapStateToProps(state) {
  return { messages: state.user.messages, houses: state.houses }
}

export default connect(mapStateToProps, { fetchUserMessages, fetchHouses })(CardUserMessages);