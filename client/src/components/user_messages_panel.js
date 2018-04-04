import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchMessages } from '../actions';
import Message from './message';
import _ from 'lodash';

class MessagesPanel extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchMessages(this.props.user.house_id);
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
      return (
        <Message message={message} hidden={this.isHidden(index)}/>
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
  return { user: state.session.user, messages: state.houses.messages}
}

export default connect(mapStateToProps, { fetchMessages })(MessagesPanel);