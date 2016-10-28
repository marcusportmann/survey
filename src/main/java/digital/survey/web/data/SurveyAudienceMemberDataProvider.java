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

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.SurveyAudienceMember;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableDataProvider;
import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyAudience;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyAudienceMemberDataProvider</code> class provides an <code>IDataProvider</code>
 * implementation that retrieves <code>SurveyAudienceMember</code> instances from the database.
 *
 * @author Marcus Portmann
 */
public class SurveyAudienceMemberDataProvider extends InjectableDataProvider<SurveyAudienceMember>
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience.
   */
  private UUID surveyAudienceId;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Constructs a new <code>SurveyAudienceMemberDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected SurveyAudienceMemberDataProvider() {}

  /**
   * Constructs a new <code>SurveyAudienceMemberDataProvider</code>.
   *
   * @param surveyAudienceId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey audience
   */
  public SurveyAudienceMemberDataProvider(UUID surveyAudienceId)
  {
    this.surveyAudienceId = surveyAudienceId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Retrieves the matching survey audience members from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey audience members retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyAudienceMember> iterator(long first, long count)
  {
    try
    {
      SurveyAudience surveyAudience = surveyService.getSurveyAudience(surveyAudienceId);

      List<SurveyAudienceMember> allSurveyAudienceMembers = surveyAudience.getMembers();

      return allSurveyAudienceMembers.subList((int) first, (int) Math.min(first + count,
          allSurveyAudienceMembers.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the survey audience members from index (%d) to (%d)", first, first
          + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyAudienceMember</code> POJO with a Wicket model.
   *
   * @param surveyAudienceMember the <code>SurveyAudienceMember</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyAudienceMember</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyAudienceMember> model(SurveyAudienceMember surveyAudienceMember)
  {
    return new DetachableSurveyAudienceMemberModel(surveyAudienceMember);
  }

  /**
   * Returns the total number of survey audience members.
   *
   * @return the total number of survey audience members
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return surveyService.getNumberOfMembersForSurveyAudience(surveyAudienceId);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException("Failed to retrieve the number of survey audience members",
          e);
    }
  }
}
