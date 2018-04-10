import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Card, Button } from '../components/bs';
import { fetchMessages } from '../actions';
import { ReactTypeformEmbed } from 'react-typeform-embed';
import Moment from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

class CardApply extends Component {
  constructor(props) {
    super(props);
    this.openForm = this.openForm.bind(this);
  }

  componentDidMount() {
    if (this.props.user) {
      this.props.fetchMessages(this.props.user.id);
    }
  }

  // return false when already applied
  // return true otherwise
  // should have a boolean flag on API
  neverApplied() {
    return _.isEmpty(this.props.userMessages);
  }

  openForm() {
    this.typeformEmbed.typeform.open();
  }

  render() {
    const { user } = this.props;

    return (
      <Card className='mb-4 d-lg-block'
            title="Séjour 😴">
        <div className='apply-popup'>
          <ReactTypeformEmbed
            url={`https://hackerhouseparis.typeform.com/to/qmztfk?firstname=${user.firstname}&lastname=${user.lastname}&email=${user.email}&user_id=${user.id}`}
            hideHeader={true}
            popup={true}
            mode="drawer_right"
            autoOpen={this.neverApplied()}
            ref={(tf => this.typeformEmbed = tf)}/>
        </div>
        <p>Viens vivre avec nous !</p>
        <Button type='primary'
                onClick={this.openForm}>
                  Postuler maintenant !
        </Button>
        {/*<button className="button btn btn-primary" onClick={this.openForm} style={{cursor: 'pointer'}}>Postuler maintenant !</button>*/}
      </Card>
    );
  }
}

function mapStateToProps(state) {
  return { user: state.session.user, userMessages: state.user.messages }
}

export default connect(mapStateToProps, { fetchMessages })(CardApply);
