import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchUserMessages, fetchHouses } from '../actions';
import Message from './message';
import MessageTitle from './message_title';
import _ from 'lodash';
import Moment from 'react-moment';

function HouseTitle(props) {
  const { house } = props
  if (_.isEmpty(house)) {
    return ''
  }

  const name = house.name

  return (
    <div>
      <strong>{name}</strong><i>, <a href='#' target="_blank">{house.zip_code}, {house.city}</a></i>
    </div>
  )

}
class UserMessagesPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchUserMessages(this.props.user.id);
      this.props.fetchHouses()
    }
  }

  toggleShowAll(e){
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      showAll: !this.state.showAll
    })
  }

  toggleText() {
    return this.state.showAll ? 'Aucun autre message' : 'Voir tous les messages'
  }

  isHidden(index) {
    if (index > 2 && !this.state.showAll) {
      return true
    }
  }

  renderMessages() {
    return _.map(this.props.messages, (message, index) => {
      const house = this.props.houses[message.house_id]
      return (
        <Message message={message}
                 created_at_prefix="Envoyé le"
                 title={<MessageTitle message={message}/>}
                 to={<HouseTitle house={house}/>}
                 hidden={this.isHidden(index)} />
      )
    });
  }

  render() {
    const staying = (this.props.user && this.props.user.house_slug_id && this.props.user.check_out)

    if (staying) {
      return (
         <div className="card mb-4 d-lg-block">
          <div className="card-body">
            <div className="d-flex flex-row justify-content-between align-items-start">
              <h6 className="mb-3">Mes messages</h6>
            </div>
            <ul className='list-unstyled'>
              {this.renderMessages()}
              <li>
                <p className="text-center">
                  <a href="#" onClick={this.toggleShowAll}>{this.toggleText()}</a>
                </p>
              </li>
            </ul>
          </div>
        </div>
      )
    } else {
      return ''
    }
  }
}

function mapStateToProps(state) {
  return { messages: state.user.messages, houses: state.houses }
}

export default connect(mapStateToProps, { fetchUserMessages, fetchHouses })(UserMessagesPanel);