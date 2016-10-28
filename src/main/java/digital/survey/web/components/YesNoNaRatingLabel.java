/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.YesNoNaRating;
import org.apache.wicket.markup.html.basic.EnumLabel;
import org.apache.wicket.model.IModel;

/**
 * The <code>YesNoNaRatingLabel</code> class implements a label component that renders the
 * description for a <code>YesNoNaRating</code> value.
 *
 * @author Marcus Portmann
 */
public class YesNoNaRatingLabel extends EnumLabel<YesNoNaRating>
{
  /**
   * Constructs a new <code>YesNoNaRatingLabel</code>.
   *
   * @param id the non-null id of this component
   */
  public YesNoNaRatingLabel(String id)
  {
    super(id);
  }

  /**
   * Constructs a new <code>YesNoNaRatingLabel</code>.
   *
   * @param id    the non-null id of this component
   * @param model the model for the component
   */
  public YesNoNaRatingLabel(String id, IModel<YesNoNaRating> model)
  {
    super(id, model);
  }

  /**
   * Converts enum value into a resource key that should be used to lookup the text the label will
   * display.
   *
   * @param value the value
   *
   * @return the resource key that should be used to lookup the text the label will display
   */
  @Override
  protected String resourceKey(YesNoNaRating value)
  {
    switch (value)
    {
      case NA:
        return "YesNoNaRatingLabel.NA";

      case NO:
        return "YesNoNaRatingLabel.No";

      case YES:
        return "YesNoNaRatingLabel.Yes";

      default:
        return "YesNoNaRatingLabel.NA";
    }
  }
}
