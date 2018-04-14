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

  componentDidMount = async () => {
    if (this.props.user) {
      const res = await this.props.fetchMessages({'q[user_id]': this.props.user.id});
      if (_.isEmpty(res)) this.typeformEmbed.typeform.open()
    }
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

const mapStateToProps = (state) => {
  return { user: state.session.user }
}

export default connect(mapStateToProps, { fetchMessages })(CardApply);
